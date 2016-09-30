## -------------------------------------------------------------------------------------------------------------
## class to handle form in the popup
##
## @extends [ModalDialog]
##
class PopupForm extends ModalDialog

    # @property [Boolean] showOnCreate if to show automatically
    showOnCreate: false

    # @property [String] content the html of the current form
    content: ""

    # @property [String] close the content of the close button
    close: "Cancel"

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor to create new popupform
    ##
    ## @param [String] tableName name of the table for which form is used
    ## @param [String] keyElement name of the key property used to track single row in the table
    ## @param [String] key current key value which is being edited
    ## @param [Array] columns the array of the columns which should be included in the form
    ## @param [Object] defualts the default values for each column in the input
    ##
    constructor: (@tableName, @keyElement, @key, @columns, @defaults) ->
        if !@keyElement
            throw new Error "Key name is not supplied in the PopupForm"

        @title = if @key then 'Edit ' else 'Create '
        @ok = if @key then 'Save Changes' else 'Create New'
        super()

        if !@columns
            @columns = DataMap.getColumnsFromTable @tableName, (c) ->
                c.editable
        ##| get formWrapper object
        @formWrapper = new PopUpFormWrapper()

        ##| generate text fields
        @createInputFields()

        @show()

    ## -------------------------------------------------------------------------------------------------------------
    ## function to create input fields
    ##
    ##
    createInputFields: () ->
        ##| if in create mode insert key column and make it required
        if !@key
            @keyColumn = DataMap.getColumnsFromTable @tableName, (c) =>
                c.source is @keyElement
            .pop()
            ##| make key column required
            @keyColumn.required = true
            @columns.unshift @keyColumn
        @columns = $.unique(@columns);
        for column in @columns
            if column.source is @keyElement
                @keyColumn = column
            value = if @key then DataMap.getDataField(@tableName, @key, column.source) else null
            if @defaults and @defaults[column.source]
                value = @defaults[column.source]
            @formWrapper.addInput column.source, column.name, value, (if !column.element then column.type else column.element), if column.options? then {options: column.options}

    ## -------------------------------------------------------------------------------------------------------------
    ## function to be executed on the click of button2
    ##
    ## @param [Event] e the event object
    ## @param [Object] form the values filled in the input as object
    ## @event onButton2
    ##
    onButton2: (e, form) ->
        valid = true
        invalidColumns = [];
        for column in @columns
            if column.required && ( !form[column.source] || form[column.source].length == 0 )
                valid = false
                invalidColumns.push column.name
        ##| required fields are not supplied
        if !valid
            alert("#{invalidColumns} are required")
            false
        else
            ##| update data
            if @key
                for column in @columns
                    DataMap.getDataMap().updatePathValue ["", @tableName, @key,
                        column.source].join("/"), form[column.source]
                @hide()
            ##| create new data
            else
                ##| onCreate callback returns true then add data to datamap
                if @onCreateNew(@tableName, form)
                    DataMap.addData @tableName, form[@keyElement], form
                    @hide()
