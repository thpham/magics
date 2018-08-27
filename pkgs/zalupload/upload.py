from datetime import datetime
from flask import Flask, flash, request, redirect, url_for, send_from_directory
from werkzeug.utils import secure_filename
from flask_sqlalchemy import SQLAlchemy
import os, hashlib

UPLOAD_FOLDER = '/tmp/uploads'
ALLOWED_EXTENSIONS = set(['txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'])

app = Flask(__name__)
app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:////tmp/uploads.db'
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
db = SQLAlchemy(app)

class UploadFile(db.Model):
  __tablename__ = 'Files'
  id = db.Column(db.Integer, primary_key=True)
  hash = db.Column(db.String(), nullable=False)
  filename = db.Column(db.String(), nullable=False)
  pub_date = db.Column(db.DateTime)

  def __init__(self, hash, filename):
        self.hash = hash
        self.filename = filename
        self.pub_date = datetime.utcnow()

  def __repr__(self):
    return '<File %r>' % self.filename


def allowed_file(filename):
  return '.' in filename and \
          filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
      # check if the post request has the file part
      if 'file' not in request.files:
        flash('No file part')
        return redirect(request.url)
      file = request.files['file']
      # if user does not select file, browser also
      # submit an empty part without filename
      if file.filename == '':
        flash('No selected file')
        return redirect(request.url)
      if file and allowed_file(file.filename):
        hash = hashlib.sha256(file.read()).hexdigest()
        file.seek(0)
        filename = secure_filename(file.filename)
        app.logger.debug('Filename: %s, Hash was: %s', filename, hash)
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], hash))
        uf = UploadFile(hash, filename)
        db.session.add(uf)
        db.session.commit()
        return redirect(url_for('uploaded_file', filename=filename))
    return '''
    <!doctype html>
    <title>Upload new File</title>
    <h1>Upload new File</h1>
    <form method=post enctype=multipart/form-data>
      <input type=file name=file>
      <input type=submit value=Upload>
    </form>
    '''

@app.route('/uploads/<filename>')
def uploaded_file(filename):
  uf = UploadFile.query.filter_by(filename=filename).first_or_404()
  return send_from_directory(app.config['UPLOAD_FOLDER'],
                              uf.hash)


if __name__ == '__main__':
  app.run()