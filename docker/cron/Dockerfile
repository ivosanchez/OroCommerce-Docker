FROM ark/php

# Install cron
RUN apt-get update && apt-get install -y cron

ADD crontab /etc/cron.d/oro-cron
RUN chmod 0644 /etc/cron.d/oro-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD cron -L 8 && tail -f /var/log/cron.log