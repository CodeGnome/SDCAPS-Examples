# Reuse the same image to create containers in each
# environment.
docker pull ruby:latest

# Bash function that exports key environment
# variables to the container, and then runs Ruby
# inside the container to display the relevant
# values.
microservice () {
    docker run -e STAGE -e DB --rm ruby \
        /usr/local/bin/ruby -e \
            'printf("STAGE: %s, DB: %s\n",
                    ENV["STAGE"],
                    ENV["DB"])'
}
