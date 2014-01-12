require 'spec_helper'

module LeaderboardFactory
  describe HelperProxy do
    it "takes on parameter to initialize, the context" do
      foo = double
      proxy = HelperProxy.new(foo)
      proxy.context.should === foo
    end
    it "includes the actual helpers" do
      HelperProxy.included_modules.should include(LeaderboardFactory::Helpers)
    end
  end
end
