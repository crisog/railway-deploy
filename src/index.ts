import { serve } from '@hono/node-server'
import { Hono } from 'hono'
import pgPool from './db'

const app = new Hono()

app.get('/', (c) => {
  return c.text('Hello Hono!')
})

app.get('/healthz', async (c) => {
  const start = performance.now()
  await pgPool.query('SELECT NOW()')
  const end = performance.now()
  console.log(`Database query took ${end - start}ms`)
  return c.text(`OK: ${end - start}ms`)
})

serve({
  fetch: app.fetch,
  port: 3000
}, (info) => {
  console.log(`Server is running on http://localhost:${info.port}`)
})
