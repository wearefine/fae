# module InertiaRails
#   class Renderer

#     def render
#       if @request.headers['X-FAE-INLINE']
#         @response.set_header('Vary', 'X-Inertia')
#         @response.set_header('X-Inertia', 'true')
#         return @render_method.call json: page, status: @response.status, content_type: Mime[:json]
#       end
#       if @request.headers['X-Inertia']
#         @response.set_header('Vary', 'X-Inertia')
#         @response.set_header('X-Inertia', 'true')
#         @render_method.call json: page, status: @response.status, content_type: Mime[:json]
#       else
#         return render_ssr if ::InertiaRails.ssr_enabled? rescue nil
#         @render_method.call template: 'inertia', layout: layout, locals: (view_data).merge({page: page})
#       end
#     end
    
#   end
# end
