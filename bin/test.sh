
redis-cli del 'test:retask:busy:q'
redis-cli del 'test:retask:out1:q'
redis-cli del 'test:retask:out2:q'
redis-cli del 'test:retask:in:q'

redis-cli lpush 'test:retask:in:q' 'm1'
redis-cli lpush 'test:retask:in:q' 'm2'
redis-cli lpush 'test:retask:in:q' 'exit'

inq='test:retask:in:q' \
busyq='test:retask:busy:q' \
outqs='test:retask:out1:q,test:retask:out2:q' \
npm start

redis-cli keys 'test:retask:*'

for key in `redis-cli keys 'test:retask:*:q'`
do
  echo; echo $key
  redis-cli lrange $key 0 -1
done
