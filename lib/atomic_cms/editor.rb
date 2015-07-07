module AtomicCms
  module Editor
    def self.included(base)
      base.extend(ClassMethods)
    end

    def edit
      render
    end

    def edit_array(inline = false)
      cms_array_node(inline) do
        edit
      end
    end

    module ClassMethods
      def from_hash(params)
        component(params.delete(:template_name)).tap do |obj|
          params.each { |key, val| obj.options[key] = from_value(key, val) }
        end
      end

      def from_array(hash)
        array = []
        hash.each do |key,element|
          array << from_hash(element)
        end
        array
      end

      def from_value(key, value)
        return from_array(value) if key === 'children'
        return from_hash(value) if Hash === value
        value
      end
    end

    protected

    def cms_node(name, inline = false, &block)
      tag = inline ? :span : :div
      h.content_tag(tag, data: { cms_node: name, ng_click: 'edit(); $event.stopPropagation();' }, &block)
    end

    def cms_array(name, inline = false, &block)
      tag = inline ? :span : :div
      h.content_tag(tag, class: 'cms-array', data: { cms_node: name }, &block)
    end

    def cms_array_node(inline = false, &block)
      tag = inline ? :span : :div
      h.content_tag(tag, class: 'cms-array-node', data: { cms_node: '', ng_click: 'edit(); $event.stopPropagation();' }, &block)
    end

    def cms_fields(fields = {})
      rtn = h.render partial: 'components/template_field', locals: { value: component_name }
      rtn << h.content_tag(:span, class: 'cms-fields') do
        fields.map do |field, type|
          h.render partial: "components/#{type}_field", locals: { name: field, value: try(field) }
        end.join('').html_safe
      end
    end

    def markdown_preview(name)
      h.content_tag :div, '', data: {ng_bind_html: "#{name} | markdown"}
    end
  end
end