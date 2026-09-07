require "test_helper"

class ContractsControllerTest < ActionDispatch::IntegrationTest
  test "line submit saves inquiry and redirects to line" do
    assert_difference "Contract.count", 1 do
      post contracts_path, params: {
        contact_via: "line",
        contract: {
          name: "山田太郎",
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
    assert_equal "東京都港区芝5-27-3", contract.address
    assert_equal "/home-care", contract.origin
    assert_equal "週3日・1日4時間", contract.service
    assert_includes contract.message, "依頼経路: LINE"
    assert_includes contract.message, "掃除希望"
    assert_response :redirect
    assert_equal LpDefinition.line_consult_url, @response.redirect_url
  end
end
