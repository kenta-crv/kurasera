class PagesController < ApplicationController
  before_action :initialize_contract
  before_action :set_breadcrumbs, except: [:index, :home_care]

  def index; end
  def baby; end
  def babysitter; end
  def housekeeping; end
  def living; end
  def home_care; end

  private

  def initialize_contract
    @contract = Contract.new
  end

  def set_breadcrumbs
    return if action_name == "index"

    add_breadcrumb "トップ", root_path
    label = LpDefinition.label(action_name)
    add_breadcrumb label, request.path if label
  end
end
