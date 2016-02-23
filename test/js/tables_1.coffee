$ ->

    ##|
    ##|  This is just for diagnostics,  you don't need to verify the data map is
    ##|  loaded normally.  The data types should be loaded upon startup.
    addTest "Confirm Zipcodes datatype loaded", () ->
        dm = DataMap.getDataMap()
        if !dm? then return false

        zipcodes = dm.types["zipcode"]
        if !zipcodes? then return false
        if !zipcodes.col["code"]? then return false

        true

    ##|
    ##|  Load the zipcodes JSON file.
    ##|  This will insert the zipcodes into the global data map.
    addTest "Loading Zipcodes", () ->

        new Promise (resolve, reject) ->
            ds  = new DataSet "zipcode"
            ds.setAjaxSource "/js/test_data/zipcodes.json", "data", "code"
            ds.doLoadData()
            .then (dsObject)->
                resolve(true)
            .catch (e) ->
                console.log "Error loading zipcode data: ", e
                resolve(false)

    addTestButton "Render table", "Open", ()->

        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.render()

        true

    addTestButton "Render table 2", "Open", ()->

        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        noAreaCode = (col)  -> col.name != "Area Code"
        filter = (obj, key) -> obj.county == "HAMPDEN"
        table.sort = (a, b) ->

            aa = DataMap.getDataField("zipcode", a.key, "city")
            bb = DataMap.getDataField("zipcode", b.key, "city")
            if aa < bb then return -1
            if aa > bb then return 1
            return 0

        table.addTable "zipcode", noAreaCode, filter
        table.render()

        true

    addTestButton "Configure Columns", "Open", ()->

        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.render()

        true

    addTestButton "Custom Column", "Open", ()->

        DataMap.setDataTypes "zipcode", [
            name    : "Custom"
            source  : "code2"
            visible : true
            type    : "text"
            width   : 300
            render  : (val, path) ->
                return "{" + path + "} = " + val
        ]

        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.render()

        true


    addTestButton "Join Table", "Open", ()->

        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.addJoinTable "county", null, "county"

        table.render()

        true

    addTestButton "Checkboxes", "Open", ()->

        addHolder("renderTest1");
        table = new TableView $("#renderTest1"), true
        table.addTable "zipcode"
        table.render()

        true

    addTestButton "context menu with sorting in header according to DataType", "Open", ()->
        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.render()
        table.setupContextMenu()
        true
        
    addTestButton "auto hide columns from left on resize", "Open", ()->
        DataMap.setDataTypes "zipcode", [
            name    : "Custom-1"
            source  : "code1"
            visible : true
            type    : "text"
            width   : 300
            render  : (val, path) ->
                return "250px"
        ]
        DataMap.setDataTypes "zipcode", [
            name    : "hidden column1"
            source  : "code2"
            visible : true
            type    : "text"
            render  : (val, path) ->
                return "can hide"
        ]
        DataMap.setDataTypes "zipcode", [
            name    : "Hidden Column2"
            source  : "code3"
            visible : true
            type    : "text"
            render  : (val, path) ->
                return "hide"
        ]
        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.render()
        #width can be dynamic as parameter | default = 32
        table.setAutoHideColumn()
        true

    addTestButton "simpleobject data type test", "Open", ()->
        ##| set the address as object in data map, to manipulate address field as simple object
        for key,obj of DataMap.getDataMap().data.zipcode
            obj.address = {city:obj.city,state:obj.state,country:obj.county}

        DataMap.setDataTypes "zipcode", [
            name    : "Address"
            source  : "address"
            visible : true
            type    : "simpleobject"
            width   : 200,
            options:
                compile: "{{city}}, {{state}}, {{country}}"
        ]
        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.render()
        true
        
    go()



