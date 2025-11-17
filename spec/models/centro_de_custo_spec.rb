require "rails_helper"

RSpec.describe CentroDeCusto, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:plano_de_pagamentos).dependent(:restrict_with_exception) }
  end

  describe "validations" do
    subject { build(:centro_de_custo) }
    it { is_expected.to validate_presence_of(:nome) }
    it { is_expected.to validate_uniqueness_of(:nome) }
  end

  describe "destroy rules" do
    context "when has planos" do
      it "raises delete restriction" do
        centro_de_custo = create(:centro_de_custo)
        create(:plano_de_pagamento, centro_de_custo: centro_de_custo)
        expect { centro_de_custo.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
      end
    end
  end
end
