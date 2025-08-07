FROM openspace-ubuntu-2204-clang17

RUN apt install -y clang-tidy-17
RUN apt install python3

COPY data/run_clang-tidy.sh /
COPY data/filter_compile_commands.py /
