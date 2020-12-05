import io
import torch 
import torch.nn as nn 
import torchvision.transforms as transforms 
import torchvision.models as models
from PIL import Image

from collections import OrderedDict
import numpy as np
import cv2



# Pre-trained Resnet152###################################################

class PVModel(nn.Module):

    def __init__(self):
        super().__init__()
        model = models.resnet152(pretrained=True)

        for param in model.parameters():
            param.requires_grad = False

        clas = nn.Sequential(OrderedDict([
            ('fc1', nn.Linear(2048, 512)),
            ('relu', nn.ReLU()),
            ('fc2', nn.Linear(512, 15)),
            ('output', nn.LogSoftmax(dim=1))
            ]))

        model.fc = clas
        self.model = model

    def forward(self, x):
        x = self.model(x)
        return x

##########################################################################




PATH = "app/val_loss: 0.30130258767258783 val_acc: 0.8962927065665133.pth"



# image -> tensor
def process_image(image):
    

    size = 256, 256
    image.thumbnail(size, Image.ANTIALIAS)
    image = image.crop((128 - 112, 128 - 112, 128 + 112, 128 + 112))
    npImage = np.array(image)
    npImage = npImage/255.
        
    imgA = npImage[:,:,0]
    imgB = npImage[:,:,1]
    imgC = npImage[:,:,2]
    
    imgA = (imgA - 0.485)/(0.229) 
    imgB = (imgB - 0.456)/(0.224)
    imgC = (imgC - 0.406)/(0.225)
        
    npImage[:,:,0] = imgA
    npImage[:,:,1] = imgB
    npImage[:,:,2] = imgC
    
    npImage = np.transpose(npImage, (2,0,1))
    
    return npImage




def load_checkpoint(filepath):  
    checkpoint = torch.load(filepath)
    model = PVModel()

    model.load_state_dict(checkpoint['model_state_dict'])
    return model, checkpoint['class_to_idx']



# predict
def get_prediction(image_tensor):

    model, class_to_idx = load_checkpoint(PATH)
    model.eval()
    idx_to_class = {v: k for k, v in class_to_idx.items()}

    output = model(image_tensor)
    probs = torch.exp(output).data.numpy()[0]

    top_idx = np.argsort(probs)[-1:][::-1]
    top_class = [idx_to_class[x] for x in top_idx]
    top_probs = probs[top_idx]
    return top_class