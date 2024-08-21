function CreateItem(id, label, price, description, imageLink, isNew)
    local self = {}

    self.id = (id or "none")
    self.label = (name or "Inconnu")
    self.price = (price or 999999)
    self.description = (description or nil)
    self.imageLink = (imageLink or nil)
    self.isNew = (isNew or false)

    function self.getId()
        return self.id
    end

    function self.getLabel()
        return self.label
    end

    function self.getPrice()
        return self.price
    end

    function self.getDescription()
        return self.description
    end

    function self.getImageLink()
        return self.imageLink
    end

    function self.getIsNew()
        return self.isNew
    end

    return self
end