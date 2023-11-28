defmodule Dryhard.Factory do
  @moduledoc """
  ExMachina Factory for generating fake data for tests and seeds.
  """
  use ExMachina.Ecto, repo: Dryhard.Repo

  alias Dryhard.User
  alias Dryhard.Comment
  alias Dryhard.Company
  alias Dryhard.Post

  def user_factory do
    %User{
      username: sequence("User "),
      bio: "bio",
      company: build(:company)
    }
  end

  def comment_factory do
    %Comment{
      content: sequence("Comment Content "),
      post: build(:post)
    }
  end

  def company_factory do
    %Company{
      name: sequence("Company ")
    }
  end

  def post_factory do
    %Post{
      title: sequence("Post Title ")
    }
  end

  defp integer_sequence(sequence_name), do: sequence(sequence_name, & &1)
  # defp float_sequence(sequence_name \\ ""), do: sequence(sequence_name, &(&1 / 1))
end
