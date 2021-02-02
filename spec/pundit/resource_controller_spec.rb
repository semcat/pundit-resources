RSpec.describe Pundit::ResourceController do
  let(:controller_class) do
    Class.new do
      include Pundit::ResourceController

      def current_user
      end
    end
  end
  let(:controller) { controller_class.new }

  describe "#context" do
    it "provides the current_user" do
      user = Object.new
      allow(controller).to receive(:current_user).and_return(user)
      expect(controller.send(:context)[:current_user]).to eq user
    end

    it "is protected" do
      expect(controller.protected_methods).to include :context
    end
  end

  context "when included" do
    def config
      JSONAPI.configuration
    end

    def allowlist
      config.exception_class_allowlist
    end

    def include_module
      Class.new(ActionController::Metal) { include Pundit::ResourceController }
    end

    before do
      # Ensure not already there from having been added previously
      config.exception_class_allowlist -= [Pundit::NotAuthorizedError]

      # Add a random value that the module couldn't guess to simulate
      # customised defaults in an application
      allowlist << SecureRandom.hex
    end

    it "adds Pundit::NotAuthorizedError to exception class allowlist when" do
      before = allowlist.dup
      include_module
      expect(allowlist).to eq(before + [Pundit::NotAuthorizedError])

      # Should not be added more than once
      expect { include_module }.not_to change { allowlist.count }
    end
  end
end
