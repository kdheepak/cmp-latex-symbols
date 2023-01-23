local source = {}

source.strategy = {
    latex = 2,
    julia = 1,
    mixed = 0,
}

local defaults = {
    strategy = source.strategy.mixed,
}

local function validate_option(params)
    local option = vim.tbl_deep_extend("keep", params.option, defaults)
    vim.validate({
        strategy = {
            option.strategy,
            function(a)
                for _, v in pairs(source.strategy) do
                    if a == v then
                        return true
                    end
                end
                return false
            end,
            "strategy",
        },
    })
    return option
end

local mixed_items = require("cmp_latex_symbols.items_mixed")
local julia_items = require("cmp_latex_symbols.items_julia")
local latex_items = require("cmp_latex_symbols.items_latex")

source.new = function()
    return setmetatable({}, { __index = source })
end

source.get_trigger_characters = function()
    return { "\\" }
end

source.get_keyword_pattern = function()
    return "\\\\[^[:blank:]]*"
end

source.complete = function(self, request, callback)
    local option = validate_option(request)
    if not vim.regex(self.get_keyword_pattern() .. "$"):match_str(request.context.cursor_before_line) then
        return callback()
    end
    if not self.items then
        if option.strategy == source.strategy.julia then
            self.items = julia_items
        elseif option.strategy == source.strategy.latex then
            self.items = latex_items
        else
            self.items = mixed_items
        end
    end
    callback(self.items)
end

return source
