FROM covid19testing-backend:latest

COPY --chown=${USER}:${USER} requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY . .

ENTRYPOINT [ "docker/entrypoint.sh" ]
CMD [ "docker/run.sh" ]