import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
  vus: 10,        // virtual users
  duration: '2m', // run for 2 minutes
};

export default function () {
  http.get('http://localhost:30011/load'); // Prod Application URL
  sleep(1);
}