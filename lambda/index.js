const http = require('http');
const jwt = require('jsonwebtoken');
const normalizeEvent = require('/opt/nodejs/normalizer');

require('dotenv').config();

const loginByCpfUrl = process.env.LOGIN_BY_CPF_URL;

exports.handler = async (event) => {
    let accessToken;

    try {
        const { pathParameters } = normalizeEvent(event);
        const cpf = pathParameters['cpf'] ?? "";
        
        http.get(loginByCpfUrl + cpf, (res) => {
            let data = '';

            res.on('data', (chunk) => {
                data += chunk;
            });

            res.on('end', () => {
                const parsedData = JSON.parse(data);
                accessToken = jwt.sign(parsedData, process.env.ACCESS_TOKEN_SECRET);
            });
        })

        return {
            status: 200,
            accessToken
        }
    } catch (error) {
        console.error(error)
        
        return {
            status: 404
        }
    }
} 