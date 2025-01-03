require('dotenv').config(); 
const express = require('express');
const { Calimero } = require('calimero');
const axios = require('axios');


const app = express();
const port = 3000;


const calimero = new Calimero({
    nodeUrl: process.env.STARKNET_NODE_URL,  
    privateKey: process.env.PRIVATE_KEY,    
    contractAddress: process.env.CONTRACT_ADDRESS  
  });

app.use(express.json());

app.post('/add_payment', async (req, res) => {
  try {
    const { payment_date, due_date, amount_due, amount_paid } = req.body;
    
    const tx = await calimero.contract('add_payment', [
      payment_date, 
      due_date, 
      amount_due, 
      amount_paid
    ]);

    res.json({ tx_hash: tx.hash });
  } catch (error) {
    console.error('Error adding payment:', error);
    res.status(500).json({ error: 'Failed to add payment' });
  }
});


app.post('/add_payments_batch', async (req, res) => {
  try {
    const { payments } = req.body;
    
    const tx = await calimero.contract('add_payments_batch', [payments]);
    
    res.json({ tx_hash: tx.hash });
  } catch (error) {
    console.error('Error adding payments batch:', error);
    res.status(500).json({ error: 'Failed to add payments batch' });
  }
});

app.post('/update_scoring_weights', async (req, res) => {
  try {
    const { on_time_weight, payment_ratio_weight } = req.body;
    
    const tx = await calimero.contract('update_scoring_weights', [
      on_time_weight, 
      payment_ratio_weight
    ]);

    res.json({ tx_hash: tx.hash });
  } catch (error) {
    console.error('Error updating scoring weights:', error);
    res.status(500).json({ error: 'Failed to update scoring weights' });
  }
});


app.post('/set_credit_score', async (req, res) => {
  try {
    const { score } = req.body;
    
    const tx = await calimero.contract('set_credit_score', [score]);

    res.json({ tx_hash: tx.hash });
  } catch (error) {
    console.error('Error setting credit score:', error);
    res.status(500).json({ error: 'Failed to set credit score' });
  }
});


app.get('/calculate_credit_score/:on_time_percent/:payment_ratio', async (req, res) => {
  try {
    const { on_time_percent, payment_ratio } = req.params;
    
    const score = await calimero.contract('calculate_credit_score', [
      on_time_percent, 
      payment_ratio
    ]);

    res.json({ score });
  } catch (error) {
    console.error('Error calculating credit score:', error);
    res.status(500).json({ error: 'Failed to calculate credit score' });
  }
});


app.get('/get_credit_score/:address', async (req, res) => {
  try {
    const { address } = req.params;
    
    const score = await calimero.contract('scores', [address]);

    res.json({ score });
  } catch (error) {
    console.error('Error getting credit score:', error);
    res.status(500).json({ error: 'Failed to get credit score' });
  }
});


app.get('/get_scoring_weights', async (req, res) => {
  try {
    const weights = await calimero.contract('scoring_weights', []);
    
    res.json({ weights });
  } catch (error) {
    console.error('Error getting scoring weights:', error);
    res.status(500).json({ error: 'Failed to get scoring weights' });
  }
});


app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
