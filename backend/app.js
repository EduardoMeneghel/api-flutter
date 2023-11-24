import express from 'express';
import cors from 'cors';

const app = express();
app.use(express.json());
app.use(cors());

import * as game from './controller/Game.js';

app.get('/game', game.findAll);
app.get('/game/:id', game.findById);
app.put('/game/:id', game.edit);
app.delete('/game/:id', game.deleteById);
app.post('/game', game.insert);

app.listen(3002, () => {
  console.log('Servidor iniciado na porta 3002');
});
