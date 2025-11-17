require "rails_helper"

RSpec.describe ResponsavelFinanceiro, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:plano_de_pagamentos).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:nome) }
  end

  describe "destroy rules" do
    context "when destroyed" do
      it "destroys associated planos" do
        responsavel_financeiro = create(:responsavel_financeiro)
        create(:plano_de_pagamento, responsavel_financeiro: responsavel_financeiro)
        expect { responsavel_financeiro.destroy }.to change { PlanoDePagamento.count }.by(-1)
      end
    end
  end
end
