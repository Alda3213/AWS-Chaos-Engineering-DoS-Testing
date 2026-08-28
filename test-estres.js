import http from 'k6/http';
import { check } from 'k6';

export const options = {
  stages: [
    { duration: '20s', target: 50 },   // Sube rápido a 50 usuarios
    { duration: '2m', target: 350 },   // 350 usuarios concurrentes por 2 minutos
    { duration: '10s', target: 0 },    // Baja a 0 usuarios
  ],
  thresholds: {
    http_req_failed: ['rate<0.10'],    // Toleramos hasta 10% de errores debido a la magnitud del ataque
  },
};

export default function () {
  const URL = 'http://tu-url'; // Aquí se pondra la url que te arroje el output en terraform
  
  let res = http.get(URL);

  check(res, {
    'status es 200': (r) => r.status === 200,
  });

}

