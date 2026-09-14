require "test_helper"

class ContractTest < ActiveSupport::TestCase
  test "company is required" do
    contract = Contract.new

    assert_not contract.valid?
    assert_includes contract.errors[:company], "を入力してください"
  end

  test "company must include a corporate suffix" do
    contract = Contract.new(company: "セールスプロ")

    assert_not contract.valid?
    assert_includes contract.errors[:company], "には「株式会社」などの法人格を含める必要があります"
  end

  test "company with a corporate suffix is valid" do
    contract = Contract.new(company: "株式会社セールスプロ")

    assert contract.valid?
  end

  test "name-only home care inquiry is valid" do
    contract = Contract.new(
      name: "山田太郎",
      address: "東京都港区芝5-27-3",
      weekly_days: "3",
      daily_hours: "4",
      period: "すぐにでも"
    )

    assert contract.valid?
    assert_equal "週3日・1日4時間", contract.service
  end

  test "typical bot inquiry is treated as spam" do
    contract = Contract.new(
      name: "qujyjxqjmk",
      tel: "+1-032-608-4793",
      address: "gnmsxjrlmi",
      email: "golanbd@gmail.com",
      message: "qsuehfnwruygkppododhkpxieywdwj",
      origin: "/living"
    )

    assert contract.spam_inquiry?
  end

  test "japanese home care inquiry is not spam" do
    contract = Contract.new(
      name: "山田太郎",
      tel: "050-1234-5678",
      address: "東京都港区芝5-27-3",
      weekly_days: "3",
      daily_hours: "4",
      period: "すぐにでも",
      origin: "/home-care"
    )

    assert_not contract.spam_inquiry?
  end

  test "bot inquiry is spam even without origin" do
    contract = Contract.new(
      name: "fnmdvsddmk",
      tel: "+1-169-353-1914",
      address: "jsenwewdxt",
      email: "shub_c@yahoo.com",
      message: "gfqrdkehinlgfyqwegoyyikisxfmsk"
    )

    assert contract.spam_inquiry?
  end

  test "honeypot website field is treated as spam" do
    contract = Contract.new(
      name: "山田太郎",
      tel: "050-1234-5678",
      address: "東京都港区芝5-27-3",
      website: "http://spam.example"
    )

    assert contract.spam_inquiry?
  end
end
