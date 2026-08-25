FROM node:24-slim AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts --legacy-peer-deps
RUN npm install ajv@8 --ignore-scripts --legacy-peer-deps

COPY . .

RUN npx sass css/main.scss css/all.bundle.css && \
    npx cleancss --skip-rebase css/all.bundle.css > css/all.css && \
    rm css/all.bundle.css

ENV NODE_OPTIONS=--max-old-space-size=8192
RUN npx webpack --mode production

RUN mkdir -p libs && \
    cp build/app.bundle.min.js build/app.bundle.min.js.map libs/ && \
    cp build/external_api.min.js build/external_api.min.js.map libs/ && \
    cp build/alwaysontop.min.js build/alwaysontop.min.js.map libs/ 2>/dev/null || true && \
    cp build/close3.min.js build/close3.min.js.map libs/ 2>/dev/null || true && \
    mkdir -p libs/chunks && \
    cp -r build/chunks/* libs/chunks/ 2>/dev/null || true && \
    cp node_modules/lib-jitsi-meet/dist/umd/lib-jitsi-meet.* libs/ 2>/dev/null || true && \
    cp node_modules/@jitsi/rnnoise-wasm/dist/rnnoise.wasm libs/ 2>/dev/null || true && \
    cp node_modules/@tensorflow/tfjs-backend-wasm/dist/*.wasm libs/ 2>/dev/null || true && \
    mkdir -p libs/excalidraw && \
    cp -r node_modules/@jitsi/excalidraw/dist/prod/fonts libs/excalidraw/ 2>/dev/null || true && \
    mkdir -p libs/mediapipe-segmentation && \
    cp node_modules/@mediapipe/selfie_segmentation/selfie_segmentation* libs/mediapipe-segmentation/ 2>/dev/null || true && \
    cp node_modules/@matrix-org/olm/olm.wasm libs/ 2>/dev/null || true

FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/conf.d/facilitymeet.conf

COPY --from=build /app/index.html /usr/share/nginx/html/
COPY --from=build /app/config.js /usr/share/nginx/html/
COPY --from=build /app/interface_config.js /usr/share/nginx/html/
COPY --from=build /app/base.html /usr/share/nginx/html/
COPY --from=build /app/body.html /usr/share/nginx/html/
COPY --from=build /app/head.html /usr/share/nginx/html/
COPY --from=build /app/title.html /usr/share/nginx/html/
COPY --from=build /app/fonts.html /usr/share/nginx/html/
COPY --from=build /app/plugin.head.html /usr/share/nginx/html/
COPY --from=build /app/pwa-worker.js /usr/share/nginx/html/
COPY --from=build /app/manifest.json /usr/share/nginx/html/
COPY --from=build /app/css/ /usr/share/nginx/html/css/
COPY --from=build /app/lang/ /usr/share/nginx/html/lang/
COPY --from=build /app/static/ /usr/share/nginx/html/static/
COPY --from=build /app/fonts/ /usr/share/nginx/html/fonts/
COPY --from=build /app/sounds/ /usr/share/nginx/html/sounds/
COPY --from=build /app/images/ /usr/share/nginx/html/images/
COPY --from=build /app/libs/ /usr/share/nginx/html/libs/

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
