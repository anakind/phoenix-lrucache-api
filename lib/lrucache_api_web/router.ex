defmodule LrucacheApiWeb.Router do
  use LrucacheApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LrucacheApiWeb do
    pipe_through :api
    post "/lrucache/:key", LruCacheController, :put
    put "/lrucache/:key", LruCacheController, :update
    get "/lrucache/:key", LruCacheController, :get
    delete "/lrucache/:key", LruCacheController, :delete
  end

  pipeline :browser do
    plug(:accepts, ["html"])
  end

  scope "/", LrucacheApiWeb do
    pipe_through :browser
    get "/", DefaultController, :index
  end
end
