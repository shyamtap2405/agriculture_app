from flask import Flask, request, jsonify
from PIL import Image
from app.torch_utils import process_image, get_prediction

import torch


app = Flask(__name__)




ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
def allowed_file(filename):
	return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS




@app.route('/predict', methods=['POST'])
def predict():
	if request.method == 'POST':
		file = request.files.get('file')
		if file is None or file.filename == "":
			return jsonify({'error': 'no file'})
		if not allowed_file(file.filename):
			return jsonify({'error': 'format not supported'}) 

		# try:
		img = Image.open(request.files['file'])
		img = torch.FloatTensor([process_image(img)])
		pred = get_prediction(img)
		return jsonify(pred)
		# except:
			# return jsonify({'error': 'error during prediction'})

	return jsonify({'result': 1})