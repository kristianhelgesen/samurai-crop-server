class TransformParams

	attr_accessor :dx, :dy, :cw, :ch, :a
  
	def initialize( params)
		@dx = 0.0
		@dy = 0.0
		@cw = 1.0
		@ch = 1.0
		@a  = 0.0

		if( params[:dx]!=nil) then
			@dx = params[:dx].to_f
		end
    
		if( params[:dy]!=nil) then
			@dy = params[:dy].to_f
		end
    
		if( params[:cw]!=nil) then
			@cw = params[:cw].to_f
		end
 
		if( params[:ch]!=nil) then
			@ch = params[:ch].to_f
		end
    
		if( params[:a]!=nil) then
			@a  = params[:a].to_f
		end
    
	end
  
end