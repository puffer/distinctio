Fabricator :book do
  name "The Adventures of Tom Sawyer"
  year 1876
end

Fabricator(:book_with_author, from: :book) do
  authors(count: 1)
end