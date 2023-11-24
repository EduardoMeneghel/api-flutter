import { openDb } from '../database.js';

const createTable = async (req, res) => {
    try {
      const db = await openDb();
      const createTableSQL = `
        CREATE TABLE IF NOT EXISTS games (
          ID INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          platform TEXT NOT NULL,
          genre TEXT NOT NULL,
          release_year INTEGER NOT NULL
        )
      `;
      await db.exec(createTableSQL);
      res.json({ message: 'Tabela "games" criada ou já existe.' });
    } catch (error) {
      console.error('Erro ao criar a tabela:', error);
      res.status(500).json({ error: 'Erro ao criar a tabela "games"', detalhes: error.message });
    }
  };

const dropTable = async (req, res) => {
    try {
        const db = await openDb();
        const createTableSQL = `DROP TABLE games`;
        await db.exec(createTableSQL);
        res.json({ message: 'Tabela "games" excluída com sucesso.' });
    } catch (error) {
        res.status(500).json({ error: 'Erro ao excluir a tabela "games"' });
    }
};

const findAll = async (req, res) => {
    try {
        const db = await openDb();
        const selectSQL = 'SELECT * FROM games';
        const data = await db.all(selectSQL);
        res.json(data);
    } catch (error) {
        console.error('Erro ao listar os jogos:', error);
        res.status(500).json({ error: 'Erro ao listar os jogos' });
    }
};

const findById = async (req, res) => {
    const id = req.params.id;
    try {
        const db = await openDb();
        const selectSQL = `SELECT * FROM games WHERE ID = ${id}`;
        const data = await db.get(selectSQL);
        if (data) {
            res.json(data);
        } else {
            res.status(404).json({ message: 'Jogo não encontrado' });
        }
    } catch (error) {
        console.error('Erro ao buscar o jogo:', error);
        res.status(500).json({ error: 'Erro ao buscar o jogo' });
    }
};

const edit = async (req, res) => {
    const id = req.params.id;
    const { name, platform, genre, release_year } = req.body;
    try {
        const db = await openDb();
        const updateSQL = `UPDATE games SET name = '${name}', platform = '${platform}', genre = '${genre}', release_year = ${parseInt(release_year, 10)} WHERE ID = ${id}`;
        await db.exec(updateSQL);
        res.json({ message: 'Jogo atualizado com sucesso' });
    } catch (error) {
        res.status(500).json({ error: 'Erro ao editar o jogo' });
    }
};

const deleteById = async (req, res) => {
    const id = req.params.id;
    try {
        const db = await openDb();
        const deleteSQL = `DELETE FROM games WHERE ID = ${id}`;
        await db.exec(deleteSQL);
        res.json({ message: 'Jogo excluído com sucesso' });
    } catch (error) {
        res.status(500).json({ error: 'Erro ao excluir o jogo' });
    }
};

const insert = async (req, res) => {
    const { name, platform, genre, release_year } = req.body;
    try {
        const db = await openDb();
        const insertSQL = `INSERT INTO games (name, platform, genre, release_year) VALUES ('${name}', '${platform}', '${genre}', ${parseInt(release_year, 10)})`;
        await db.exec(insertSQL);
        res.json({ message: 'Jogo inserido com sucesso' });
    } catch (error) {
        res.status(500).json({ error: 'Erro ao inserir o jogo' });
    }
};

export {
    createTable,
    dropTable,
    findAll,
    findById,
    edit,
    deleteById,
    insert,
};