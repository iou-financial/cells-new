require "test_helper"

class ContextTest < Minitest::Spec
  class ParentCellNew < CellNew::ViewModel
    def user
      context[:user]
    end

    def controller
      context[:controller]
    end
  end

  let (:model) { Object.new }
  let (:user) { Object.new }
  let (:controller) { Object.new }

  let (:parent) { ParentCellNew.(model, admin: true, context: { user: user, controller: controller }) }

  it do
    assert_equal model, parent.model
    assert_equal controller, parent.controller
    assert_equal user, parent.user

    # nested cell_new
    child = parent.cell_new("context_test/parent", "")

    assert_equal "", child.model
    assert_equal controller, child.controller
    assert_equal user, child.user
  end

  # child can add to context
  it do
    child = parent.cell_new(ParentCellNew, nil, context: { "is_child?" => true })

    assert_nil parent.context["is_child?"]

    assert_nil child.model
    assert_equal controller, child.controller
    assert_equal user, child.user
    assert_equal true, child.context["is_child?"]
  end
end
