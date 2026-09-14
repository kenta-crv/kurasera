require "test_helper"

class ContractsControllerTest < ActionDispatch::IntegrationTest
  test "line submit saves inquiry, notifies info@j-work.jp, and shows sent ui" do
    ActionMailer::Base.deliveries.clear

    assert_difference "Contract.count", 1 do
      post contracts_path, params: {
        contact_via: "line",
        contract: {
          name: "山田太郎",
          tel: "050-1234-5678",
          address: "東京都港区芝5-27-3",
          weekly_days: "3",
          daily_hours: "4",
          period: "すぐにでも",
          message: "掃除希望",
          origin: "/home-care"
        }
      }
    end

    contract = Contract.order(:id).last
    assert_equal "山田太郎", contract.name
    assert_equal "050-1234-5678", contract.tel
    assert_equal "東京都港区芝5-27-3", contract.address
    assert_equal "/home-care", contract.origin
    assert_equal "週3日・1日4時間", contract.service
    assert_includes contract.message, "依頼経路: LINE"
    assert_includes contract.message, "掃除希望"
    assert_redirected_to "/home-care?sent=1"

    mail = ActionMailer::Base.deliveries.last
    assert_not_nil mail
    assert_equal ["info@j-work.jp"], mail.to
    assert_includes mail.body.encoded, "050-1234-5678"
  end

  test "spam inquiry is dropped without saving or mailing" do
    ActionMailer::Base.deliveries.clear

    assert_no_difference "Contract.count" do
      post contracts_path, params: {
        contract: {
          name: "qujyjxqjmk",
          tel: "+1-032-608-4793",
          address: "gnmsxjrlmi",
          email: "golanbd@gmail.com",
          message: "qsuehfnwruygkppododhkpxieywdwj",
          origin: "/living"
        }
      }
    end

    assert_redirected_to "/living?sent=1"
    assert_empty ActionMailer::Base.deliveries
  end

  test "spam inquiry without origin is dropped without saving or mailing" do
    ActionMailer::Base.deliveries.clear

    assert_no_difference "Contract.count" do
      post contracts_path, params: {
        contract: {
          name: "fnmdvsddmk",
          tel: "+1-169-353-1914",
          address: "jsenwewdxt",
          email: "shub_c@yahoo.com",
          message: "gfqrdkehinlgfyqwegoyyikisxfmsk"
        }
      }
    end

    assert_redirected_to "/?sent=1"
    assert_empty ActionMailer::Base.deliveries
  end
end
