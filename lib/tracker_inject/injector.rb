class Injector
  module Filter
    extend ActiveSupport::Concern
    included do
      append_after_filter :add_gosquared_script, :if => :html_response?

      CLOSING_HEAD_TAG = %r{</head>}
      CLOSING_BODY_TAG = "</body>"

      def add_gosquared_script
        response.body = response.body.gsub(CLOSING_HEAD_TAG, "<script>

          (function() {
            if (window._gs) return;
              !function(g,s,q,r,d){r=g[r]=g[r]||function(){(r.q=r.q||[]).push(
                arguments)};d=s.createElement(q);q=s.getElementsByTagName(q)[0];
        d.src='//d1l6p2sc9645hc.cloudfront.net/tracker.js';q.parentNode.
        insertBefore(d,q)}(window,document,'script','_gs');
        _gs('#{GosquaredRails.configure.site_token}', false);
        #{GosquaredRails.configure.config_options}


        function track() {
          _gs('track');
        }
        $(document).on('page:load', track);
        $(document).on('turbolinks:load', track);

        $(document)
        .on('turbolinks:before-render', function(event){
          var chat = $('[id^=\"gs_\"]');
          if (chat.length) {
            chat
            .detach()
            .appendTo(event.originalEvent.data.newBody);
          }
          })
        .on('turbolinks:render', function() {
          try {
            window.dispatchEvent(new Event('resize'));
            } catch (e) {}
            })
})();

</script>" + "\n </head>"
)


end

def html_response?
  response.content_type == "text/html"
end

def add_gosquared_identify_method(current_user)
  @hash = {id: '1', email: 'russell@gmail.com', name: 'russell vaughan',
   first_name: 'russell', last_name: 'vaughan',
   username: 'povrus',
   phone: '6047877820',
   created_at: '03/11/1982',
   favourite_team: 'Tottenham',
   monthly_mrr: '0' }

   if current_user
    validate_properties(current_user)
    sort_property_fields(@hash)
    response.body = response.body.gsub(CLOSING_BODY_TAG, "<script>
      _gs('identify',
        #{gosquared_standard_properties}
        #{gosquared_custom_properties}
        });
    </script>" + "\n </body>"
    )
  end
end

def validate_properties(current_user)
  @hash.each do |key, value|
  if current_user.methods.include? key || value.class === String
end

end


def sort_property_fields(hash)
  property_fields = ['id', 'email', 'name', 'first_name', 'last_name',
    'username', 'phone', 'created_at']

    @standard_properties_hash = {}
    @custom_properties_hash = {}
    hash.each do | key, value |
      property_fields.each do | property |
       if key.to_s === property
        @standard_properties_hash[key] = value
        hash.except!(key)
      end
      @custom_properties_hash = hash
    end
  end
end

def gosquared_custom_properties
  @custom_properties = "custom: { \n "
  @custom_properties_hash.each do |key, value|
   @custom_properties  << "#{key}: '#{value}',\n "
 end
 @custom_properties << '}'
end

def gosquared_standard_properties
  @standard_properties=  " { \n "
  @standard_properties_hash.each do |key, value|
   @standard_properties  << "#{key}: '#{value}',\n "
 end
 @standard_properties << '}' if @custom_properties_hash.empty?
 @standard_properties

end

end


end

end
