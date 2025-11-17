class CreateResponsavelFinanceiros < ActiveRecord::Migration[8.1]
  def change
    create_table :responsavel_financeiros do |t|
      t.string :nome, null: false

      t.timestamps
    end
  end
end
