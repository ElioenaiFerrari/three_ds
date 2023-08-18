FROM elixir:1.15-otp-24-alpine

ENV MIX_ENV="prod"
ENV SECRET_KEY="cHvh6f8yEXZ768ftUUwTSw=="
ENV TDS_PROVIDER_API_KEY="44850eed-d3c7-48a5-9fe8-7a2c594fa0a4"
ENV TDS_PROVIDER_BASE_URL="https://service.sandbox.3dsecure.io"

WORKDIR /app
COPY . .

RUN apk add --update build-base
RUN mix do deps.get, ecto.create, ecto.migrate
RUN mix release

EXPOSE 4000

CMD [ "mix", "run" ]