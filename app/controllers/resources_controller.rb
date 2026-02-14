class ResourcesController < ApplicationController

  def index
    @videos = Resource.by_category('video').newest
    @documents = Resource.by_category('document').newest
    @media = Resource.by_category('media').newest
  end

  private
  # Write your private methods here
end
