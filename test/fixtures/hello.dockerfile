FROM alpine

ARG hello=world
RUN echo $hello
CMD ["/bin/sh", "-c", "echo ${hello}"]