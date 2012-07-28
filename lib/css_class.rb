class String
	def css_class(str, prefix)
  	"#{prefix}-#{str.downcase.gsub(/\W/, "-")}" if str.present?
	end
end