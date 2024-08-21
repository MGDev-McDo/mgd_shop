function CreateCategorie(id, label, event, items)
    local self = {}

    self.id = (id or "none")
    self.label = (label or "Inconnu")
    self.event = (event or "error")
    self.items = (items or {})

    function self.getId()
        return self.id
    end

    function self.getLabel()
        return self.label
    end

    function self.getEvent()
        return self.event
    end
    
    function self.getItems()
        return self.items
    end

    return self
end