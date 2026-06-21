class ColumnsController < ApplicationController
    def index
      #@columns = Column.order(created_at: "DESC").page(params[:page])
    end
  
    def show
      #@column = Column.find(params[:id])
    end
end
