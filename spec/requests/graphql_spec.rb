require "rails_helper"

RSpec.describe "GraphQL", type: :request do
  it "lista centros de custo" do
    create_list(:centro_de_custo, 2)
    post "/graphql", params: { query: "{ centrosDeCusto { id nome } }" }
    body = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    expect(body.dig("data", "centrosDeCusto").size).to eq(2)
  end

  it "registra pagamento via mutation" do
    r = create(:responsavel_financeiro)
    cc = create(:centro_de_custo)
    plano = create(:plano_de_pagamento, responsavel_financeiro: r, centro_de_custo: cc)
    c = plano.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :boleto, status: :emitida)
    mutation = <<~GQL
      mutation { registrarPagamento(cobrancaId: #{c.id}, valor: 100.0) { id valorCents cobrancaId } }
    GQL
    post "/graphql", params: { query: mutation }
    body = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    expect(body.dig("data", "registrarPagamento", "id")).to be_present
    expect(c.reload.status).to eq("paga")
  end

  it "consulta plano por id" do
    r = create(:responsavel_financeiro)
    cc = create(:centro_de_custo)
    plano = create(:plano_de_pagamento, responsavel_financeiro: r, centro_de_custo: cc)
    plano.cobrancas.create!(valor_cents: 150_00, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :emitida)
    plano.calcular_total!
    query = <<~GQL
      { plano(id: #{plano.id}) { id valorTotalCents cobrancas { id metodoPagamento status } } }
    GQL
    post "/graphql", params: { query: query }
    body = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    expect(body.dig("data", "plano", "id")).to eq(plano.id)
    expect(body.dig("data", "plano", "valorTotalCents")).to eq(15000)
    expect(body.dig("data", "plano", "cobrancas").size).to eq(1)
  end

  it "lista planos do responsável" do
    r = create(:responsavel_financeiro)
    cc = create(:centro_de_custo)
    create(:plano_de_pagamento, responsavel_financeiro: r, centro_de_custo: cc)
    create(:plano_de_pagamento, responsavel_financeiro: r, centro_de_custo: cc)
    query = <<~GQL
      { planosDoResponsavel(responsavelId: #{r.id}) { id } }
    GQL
    post "/graphql", params: { query: query }
    body = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    expect(body.dig("data", "planosDoResponsavel").size).to eq(2)
  end

  it "lista cobranças do responsável com filtros" do
    r = create(:responsavel_financeiro)
    cc = create(:centro_de_custo)
    plano = create(:plano_de_pagamento, responsavel_financeiro: r, centro_de_custo: cc)
    plano.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :boleto, status: :emitida)
    plano.cobrancas.create!(valor_cents: 200_00, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :emitida)
    query = <<~GQL
      { cobrancasDoResponsavel(responsavelId: #{r.id}, metodoPagamento: "boleto", status: "emitida") { id metodoPagamento status } }
    GQL
    post "/graphql", params: { query: query }
    body = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    list = body.dig("data", "cobrancasDoResponsavel")
    expect(list.size).to eq(1)
    expect(list.first["metodoPagamento"]).to eq("boleto")
    expect(list.first["status"]).to eq("emitida")
  end

  it "retorna quantidade de cobranças do responsável" do
    r = create(:responsavel_financeiro)
    cc = create(:centro_de_custo)
    plano = create(:plano_de_pagamento, responsavel_financeiro: r, centro_de_custo: cc)
    plano.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :boleto, status: :emitida)
    plano.cobrancas.create!(valor_cents: 200_00, data_vencimento: Date.tomorrow, metodo_pagamento: :pix, status: :emitida)
    query = <<~GQL
      { cobrancasQuantidade(responsavelId: #{r.id}) }
    GQL
    post "/graphql", params: { query: query }
    body = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    expect(body.dig("data", "cobrancasQuantidade")).to eq(2)
  end

  it "cria plano via mutation" do
    r = create(:responsavel_financeiro)
    cc = create(:centro_de_custo)
    mutation = <<~GQL
      mutation {
        criarPlano(
          responsavelId: #{r.id},
          centroDeCustoId: #{cc.id},
          cobrancas: [{ valor: 100.0, dataVencimento: "#{Date.tomorrow}", metodoPagamento: "boleto" }]
        ) {
          id valorTotalCents
        }
      }
    GQL
    post "/graphql", params: { query: mutation }
    body = JSON.parse(response.body)
    expect(response).to have_http_status(:ok)
    expect(body.dig("data", "criarPlano", "valorTotalCents")).to eq(10000)
  end
end
