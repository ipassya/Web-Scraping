library(writexl)
library(rvest)
library(dplyr)

get_cast = function(movie_link) {
  movie_page = read_html(movie_link)
  movie_cast = movie_page %>% html_nodes(".primary_photo+ td a") %>%
    html_text() %>% paste(collapse = ",")
  return(movie_cast)
}

movies = data.frame()

for (page_result in seq(from = 1, to = 1001, by = 50)) {
  link = paste0("https://www.imdb.com/search/title/?release_date=2015-01-01,2020-12-31&user_rating=1.0,10.0&start=",
                page_result, "&ref_=adv_nxt")
  page = read_html(link)
  
  name = page %>% html_nodes(".lister-item-header a") %>% html_text()
  genre = page %>% html_nodes(".genre") %>% html_text()
  year = page %>% html_nodes(".text-muted.unbold") %>% html_text()
  rating = page %>% html_nodes(".ratings-imdb-rating strong") %>% html_text()
  votes = page %>% html_nodes(".sort-num_votes-visible span:nth-child(2)") %>% html_text()
  movie_links = page %>% html_nodes(".lister-item-header a") %>%
    html_attr("href") %>% paste("https://www.imdb.com", ., sep="")
  cast = sapply(movie_links, FUN = get_cast, USE.NAMES = FALSE)
  
  
  movies = rbind(movies, data.frame(name, year, genre, rating, votes, cast, stringsAsFactors = FALSE))
  
  print(paste("Page:", page_result))
}

write_xlsx(movies, "movies.xlsx")
