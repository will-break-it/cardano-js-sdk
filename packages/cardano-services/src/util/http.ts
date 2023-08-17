import * as OpenApiValidator from 'express-openapi-validator';
import { Application, Router } from 'express';
import { ListenOptions } from 'net';
import http from 'http';

export const listenPromise = (
  serverLike: http.Server | Application,
  listenOptions: ListenOptions = {}
): Promise<http.Server> =>
  new Promise((resolve, reject) => {
    const server = serverLike.listen(listenOptions, () => resolve(server)) as http.Server;
    server.on('error', reject);
  });

export const serverClosePromise = (server: http.Server): Promise<void> =>
  new Promise((resolve, reject) => {
    server.once('close', resolve);
    server.close((error) => (error ? reject(error) : null));
  });

export const useOpenApi = (apiSpec: string, router: Router) => {
  router.use(
    OpenApiValidator.middleware({ apiSpec, ignoreUndocumented: true, validateRequests: true, validateResponses: true })
  );
};
