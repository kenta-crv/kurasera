class PagesController < ApplicationController
  before_action :initialize_contract

  def index; end
  def baby; end
  def babysitter; end
  def housekeeping; end

  private

  def initialize_contract
    @contract = Contract.new
  end

  def set_breadcrumbs
    add_breadcrumb 'トップ', root_path

    label = LpDefinition.label(action_name)
    add_breadcrumb label, request.path if label
  end
end
