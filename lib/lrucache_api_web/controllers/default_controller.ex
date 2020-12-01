defmodule LrucacheApiWeb.DefaultController do
  use LrucacheApiWeb, :controller

  def index(conn, _params) do
    text conn, "LruCacheApi!"
  end
end