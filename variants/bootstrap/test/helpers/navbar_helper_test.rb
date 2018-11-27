require "test_helper"

class NavbarHelperTest < ActionView::TestCase
  include NavbarHelper

  test "#navbar_link_to adds active class according to :active_when" do
    stubs(:params).returns(controller: "users")

    tag = navbar_link_to(
      "Test",
      "http://example.com",
      title: "foo",
      active_when: { controller: "users" }
    )

    assert_equal(
      '<li class="active">'\
      '<a title="foo" href="http://example.com">Test</a>'\
      "</li>",
      tag
    )
  end

  test "#navbar_link_to honors regular expressions" do
    stubs(:params).returns(controller: "users")

    tag = navbar_link_to(
      "Test",
      "http://example.com",
      active_when: { controller: /^user.*/ }
    )

    assert_equal(
      '<li class="active"><a href="http://example.com">Test</a></li>',
      tag
    )
  end

  test "#navbar_link_to otherwise doesn't add active class" do
    stubs(:params).returns(controller: "users")
    tag = navbar_link_to("Welcome", "/", active_when: { controller: "web/welcome" })
    assert_equal('<li><a href="/">Welcome</a></li>', tag)
  end
end
