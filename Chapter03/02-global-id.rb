require_relative "./prelude"

user = User.find(1)

user.to_global_id

# Custom global ID locator
GlobalID::Locator.use :pogo do |gid|
  gid.model_name.constantize.new(**gid.params)
end

# Global identifieable struct
class Category < Struct.new(:name, keyword_init: true)
  include GlobalID::Identification

  alias_method :id, :name

  def to_global_id(options = {})
    super({name:}.merge!(options).merge!(app: "pogo"))
  end
end

original = Category.new(name: "ruby")

located = GlobalID::Locator.locate(original.to_global_id)

located == original
