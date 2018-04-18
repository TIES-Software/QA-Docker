FROM debian:jessie

RUN system_type=$(uname -m) \
    && echo $system_type \
    && if [ $system_type = 'i686' ]; then bit='32'; elif [ $system_type = 'x86_64' ]; then bit='64'; fi \
    && echo $bit

CMD ["bash"]
