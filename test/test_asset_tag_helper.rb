require "lazyload-rails_test"

class BasicController
  attr_accessor :request

  def config
    @config ||= ActiveSupport::InheritableOptions.new(ActionController::Base.config).tap do |config|
      public_dir = File.expand_path("../fixtures/public", __FILE__)
      config.assets_dir = public_dir
      config.assets = ActiveSupport::InheritableOptions.new({ :prefix => "assets" })
      config
    end
  end
end

class AssetTagHelperTest < ActionView::TestCase
  tests ActionView::Helpers::AssetTagHelper

  attr_reader :request

  def setup
    super

    @controller = BasicController.new

    @request = Class.new do
      attr_accessor :script_name
      def protocol() 'http://' end
      def ssl?() false end
      def host_with_port() 'localhost' end
      def base_url() 'http://www.example.com' end
    end.new

    @controller.request = @request
  end

  def test_lazy_attributes
    Lazyload::Rails.reset

    expected = '<img alt="Foo" height="150"' +
      ' src="http://www.appelsiini.net/projects/lazyload/img/grey.gif"' +
      ' width="100" data-original="/images/foo.png">'

    assert_equal expected, image_tag("foo.png", size: "100x150", lazy: true)
  end

  def test_lazy_attributes_override
    Lazyload::Rails.reset

    expected = '<img alt="Bar" data-original="/images/bar.png" height="150"' +
      ' src="http://www.appelsiini.net/projects/lazyload/img/grey.gif" width="200">'

    options = { size: "200x150", data: { original: "foo" }, lazy: true }
    actual = image_tag("bar.png", options)

    assert_equal expected, actual
  end

  def test_custom_placeholder
    Lazyload::Rails.configure do |config|
      config.placeholder = "/public/img/grey.gif"
    end

    expected = '<img alt="Baz" height="250" src="/public/img/grey.gif"' +
      ' width="100" data-original="/images/baz.png">'

    assert_equal expected, image_tag("baz.png", size: "100x250", lazy: true)
  end

  def test_on_the_fly_custom_placeholder
    Lazyload::Rails.configure do |config|
      config.placeholder = "/public/img/grey.gif"
    end

    expected = '<img alt="Baz" height="250" src="/public/img/grey.gif"' +
      ' width="100" data-original="/images/baz.png">'

    options = { size: "200x150", data: { placeholder: "/public/img/grey.gif" }, lazy: true }
    assert_equal expected, image_tag("baz.png", options)
  end

  def test_setting_class
    Lazyload::Rails.configure do |config|
      config.additional_class = "lazyload"
    end

    expected = '<img src="/public/img/grey.gif" alt="Baz" width="100" height="250"' +
      ' data-original="/images/baz.png" class="lazyload">'

    assert_equal expected, image_tag("baz.png", size: "100x250", lazy: true)
  end

  def test_adding_class
    Lazyload::Rails.configure do |config|
      config.additional_class = "lazyload"
    end

    expected = '<img class="initial-class lazyload" src="/public/img/grey.gif" alt="Baz"' +
      ' width="100" height="250" data-original="/images/baz.png">'

    assert_equal expected, image_tag("baz.png", size: "100x250", class: "initial-class", lazy: true)
  end

  def test_nonlazy_attributes
    Lazyload::Rails.reset

    expected = '<img alt="Foo" height="150" src="/images/foo.png" width="100" />'

    assert_equal expected, image_tag("foo.png", size: "100x150", lazy: false)
    assert_equal expected, image_tag("foo.png", size: "100x150")
  end

  def test_empty_options
    expected = '<img alt="Foo" src="/images/foo.png" />'
    assert_equal expected, image_tag("foo.png")
  end
end
