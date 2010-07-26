
module AssetPocket
    module ViewHelperMethods
        def sprite_tag(name, options = {})
            # TODO options: tag_name, :class, :style, something like that
            # TODO Generate the CSS class name inside AssetPocket, and not hardcoded
            group, image = name.split("/")
            %[<span class="sprite-#{group}--#{image}">&nbsp;</span>].html_safe
        end
    end
end

ActionView::Base.class_eval do
    include AssetPocket::ViewHelperMethods
end
