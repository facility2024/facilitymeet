FROM node:24-slim AS build

WORKDIR /app

COPY package.json ./
RUN npm install --ignore-scripts

COPY . .

RUN npx sass css/main.scss css/all.bundle.css && \
    npx cleancss --skip-rebase css/all.bundle.css > css/all.css && \
    rm css/all.bundle.css

ENV NODE_OPTIONS=--max-old-space-size=8192
RUN npx webpack --mode production

FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/conf.d/facilitymeet.conf

COPY --from=build /app/build /usr/share/nginx/html
COPY --from=build /app/index.html /usr/share/nginx/html/
COPY --from=build /app/css /usr/share/nginx/html/css
COPY --from=build /app/lang /usr/share/nginx/html/lang

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
