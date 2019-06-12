#require_relative "../app/models/pdf_ecad.rb"
require "test_helper"
describe "Ecad PDF Import" do
  before(:each) do
    @importer = Importers::PdfEcad.new("#{Rails.root}/spec/lib/importers/careqa.pdf")
  end

  it "should list all works" do
    expect(@importer.works.count).to eq(130)
    expect(@importer.works[0][:iswc]).to eq("T-039.782.970-7")
    expect(@importer.works.last[:external_ids][0][:source_id]).to eq("126227")
    expect(@importer.works[9][:right_holders].size).to eq(4)
    expect(@importer.works[4][:right_holders][1][:society_name]).to eq("UBC")
    expect(@importer.works[15][:right_holders][0][:role]).to eq("Versionist")
    expect(@importer.works[9][:right_holders][2][:share]).to eq(25.00)
  end

  it "should recognize a right holder for 100% line" do
    line = "4882         CARLOS DE SOUZA                        CARLOS CAREQA            582.66.28.18 ABRAMUS          CA   100,                        1"
    rh = @importer.right_holder(line)
    expect(rh[:name]).to eq("CARLOS DE SOUZA")
    expect(rh[:pseudos][0][:name]).to eq("CARLOS CAREQA")
    expect(rh[:pseudos][0][:main]).to eq(true)
    expect(rh[:role]).to eq("Author")
    expect(rh[:society_name]).to eq("ABRAMUS")
    expect(rh[:ipi]).to eq("582662818")
    expect(rh[:external_ids][0][:source_name]).to eq("Ecad")
    expect(rh[:external_ids][0][:source_id]).to eq("4882")
    expect(rh[:share]).to eq(100)
  end

  it "should recognize share for broken percent" do
    line = "16863        EDILSON DEL GROSSI FONSECA             EDILSON DEL GROSSI                     SICAM           CA 33,33                         2"
    rh = @importer.right_holder(line)
    expect(rh[:name]).to eq("EDILSON DEL GROSSI FONSECA")
    expect(rh[:share]).to eq(33.33)
    expect(rh[:ipi]).to be_nil
  end

  it "should recognize share in right holder line" do
    line = "741          VELAS PROD. ARTISTICAS MUSICAIS E      VELAS                    247.22.09.80 ABRAMUS           E   8,33 20/09/95               2"
    rh = @importer.right_holder(line)
    expect(rh[:name]).to eq("VELAS PROD. ARTISTICAS MUSICAIS E")
    expect(rh[:share]).to eq(8.33)
  end

  it "should return nil if it is not a right_holder" do
    line = "3810796       -   .   .   -          O RESTO E PO                                                LB             18/03/2010"
    rh = @importer.right_holder(line)
    expect(rh).to be_nil
  end

  it "should recognize work in line" do
    line = "3810796       -   .   .   -          O RESTO E PO                                                LB             18/03/2010"
    work = @importer.work(line)
    expect(work).not_to be_empty
    expect(work[:iswc]).to eq("-   .   .   -")
    expect(work[:title]).to eq("O RESTO E PO")
    expect(work[:external_ids][0][:source_name]).to eq("Ecad")
    expect(work[:external_ids][0][:source_id]).to eq("3810796")
    expect(work[:situation]).to eq("LB")
    expect(work[:created_at]).to eq("18/03/2010")
  end

  it "should recognize iswc" do
    line = "3810796       T-039.370.915-3        O RESTO E PO                                                LB             18/03/2010"
    work = @importer.work(line)
    expect(work).not_to be_empty
    expect(work[:iswc]).to eq("T-039.370.915-3")
    expect(work[:title]).to eq("O RESTO E PO")
    expect(work[:external_ids][0][:source_name]).to eq("Ecad")
    expect(work[:external_ids][0][:source_id]).to eq("3810796")
    expect(work[:situation]).to eq("LB")
    expect(work[:created_at]).to eq("18/03/2010")
  end

end
